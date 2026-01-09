using AutoMapper;
using EchoAPI.Api.DTOs.Requests;
using EchoAPI.Api.DTOs.Response;
using EchoAPI.Core.Entities;

namespace EchoAPI.Api.Mappings
{
    public class VocabularyProfile : Profile
    {
        public VocabularyProfile()
        {
            CreateMap<Vocabulary, VocabularyResponse>()
                .ForMember(dest => dest.AddedFrom, opt => opt.MapFrom(src => src.AddedFrom.ToString()))
                .ForMember(dest => dest.KnowledgeLevel, opt => opt.MapFrom(src => src.KnowledgeLevel.ToString()));
            CreateMap<AddVocabularyRequest, Vocabulary>();
        }
    }
}
